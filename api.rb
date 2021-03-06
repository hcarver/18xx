# frozen_string_literal: true

require 'execjs'
require 'opal'
require 'roda'
require 'snabberb'

require_relative 'models'
require_relative 'lib/tilt/opal_template'

Dir['./models/**/*.rb'].sort.each { |file| require file }

class Api < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         # 'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
         'X-Frame-Options' => 'deny',
         # 'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :self
    csp.style_src :self
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  plugin :not_found do
    @page_title = 'File Not Found'
    ''
  end

  plugin :error_handler

  error do |e|
    puts e.backtrace.reverse
    puts "#{e.class}: #{e.message}"
    { code: 500, message: e }
  end

  plugin :assets, js: 'app.rb'

  compile_assets
  APP_JS_PATH = assets_opts[:compiled_js_path]
  APP_JS = "#{APP_JS_PATH}.#{assets_opts[:compiled]['js']}.js"
  Dir[APP_JS_PATH + '*'].sort.each { |file| File.delete(file) if file != APP_JS }
  CONTEXT = ExecJS.compile(File.open(APP_JS, 'r:UTF-8', &:read))

  plugin :public
  plugin :multi_route
  plugin :streaming
  plugin :json
  plugin :json_parser

  ROOMS = Hash.new { |h, k| h[k] = [] }

  PING_FUNC = lambda do |*|
    ROOMS
      .values
      .flatten
      .select(&:empty?)
      .each { |q| q.push('{"type":"ping"}') }
  end

  Thread.new do
    loop do
      PING_FUNC.call
      sleep(1)
    end
  end

  Thread.new do
    DB.listen(:channel, loop: PING_FUNC) do |_, _, payload|
      notification = JSON.parse(payload)
      message = JSON.dump(notification['message'])
      room = ROOMS[notification['room_id']]
      room.each { |q| q.push(message) }
    end
  end

  def notify(room_id, message)
    notification = {
      'room_id' => room_id,
      'message' => message,
    }

    DB.notify(:channel, payload: JSON.dump(notification))
  end

  def on_close(room, q)
    room.delete(q)
  end

  Dir['./routes/*'].sort.each { |file| require file }

  route do |r|
    r.public
    r.assets
    r.multi_route

    r.root do
      render
    end

    r.on %w[signup login profile] do
      render
    end
  end

  def render(**needs)
    script = Snabberb.prerender_script(
      'Index',
      'App',
      'app',
      javascript_include_tags: assets(:js),
      app_route: request.path,
      **needs,
    )

    CONTEXT.eval(script)
  end

  def session
    return unless (token = request.env['HTTP_AUTHORIZATION'])

    @session ||= Session.find(token: token)
  end

  def user
    session&.valid? ? session.user : nil
  end
end
