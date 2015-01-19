#========================= RUBY BUNNY
# A dead easy to use RabbitMQ Ruby client. Now feature complete.
# Bunny is a popular, easy to use, well-maintained Ruby client for RabbitMQ (3.3+)

#* all information about bunny
#* publishing and subscribing
#* setting up queues and exchagnes
#* http://rubybunny.info/articles/getting_started.html

# Bunny creates a calss
Bunny
Bunny::VERSION

# Make sure rabbit mq server is running. Bunny has a client.

# Basic 1:1 example
conn = Bunny.new
conn.start
# The connection gets started. This can be seen in the rabbit mq management dashboard.

ch = conn.create_channel
q  = ch.queue("bunny.examples.hello_world", :auto_delete => true)
x  = ch.default_exchange

q.subscribe do |delivery_info, metadata, payload|
  puts "Received #{payload}"
end

x.publish("Hello!", :routing_key => q.name)

sleep 1.0
conn.close


# message is always publoished to exchange
# a routing key may also be provided
# http://codetunes.com/2014/event-sourcing-on-rails-with-rabbitmq/
# http://blog.brianploetz.com/post/36886084370/producing-amqp-messages-from-ruby-on-rails#
# http://rubybunny.info/articles/getting_started.html
