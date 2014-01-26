# PrimeService

A gem for Service Objects.




## Installation

Add this line to your application's Gemfile:

    gem 'prime_service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prime_service




## Usage


### Definition of a simple service

```ruby
class MarkMessageAsRead < PrimeService::Service
  call_with :message

  def call
    message.read = true
  end
end
```



### Definition of a service with a factory method

If the behavior of the service should be different depending on the passed parameter(s), you can override the `.for` factory method and derive service subclasses which implement the desired behavior.

Anyway `.for` may return any object that responds to `#call` with no parameters passed. So e.g. a `Proc` would be fine too.

```ruby
class MarkMessageAsRead < RailsPrimer::Service
  call_with :message

  def self.for(message)
    if message.demand_read_notification?
      WithNotification.new(message)
    else
      NoNotification.new(message)
    end
  end

  class NoNotification < self
    def call
      message.read = true
    end
  end

  class WithNotification < self
    def call
      SendReadNotification.call(message)
      message.read = true
    end
  end
end
```


### Calling the Service Object

The service object is called using the `.call` class method. All parameters that are needed to perform the desired actions are passed to this method as parameters.

```ruby
MarkMessageAsRead.call(message)
```

You can also initialize the service object and call it later. Use the `.for` method for initialization not `.new`. This enables you to override the factory method as shown above.

```ruby
service = MarkMessageAsRead.for(message)
# do other stuff
service.call
```


### Example: Usage in a controller

Mark a message as read. This should never fail, so we can use `#save!`. Note that `#save` is called by the controller. This is by convention, see (Conventions)[#conventions] below.

```ruby
class MessagesController < ApplicationController
  def mark_as_read
    message = Message.find(params[:id])
    MarkMessageAsRead.call(message) and message.save!
    
    redirect_to messages_path
  end
end
```

Sharing a message on Twitter. If sharing on Twitter fails, the message should not be created.

```ruby
class MessagesController < ApplicationController
  def create
    @messages = Message.new(params[:message])

    if ShareMessageOnTwitter.call(@message) && @message.save
      redirect_to @message
    else
      render "new"
    end
  end
end
```


### Conventions

* A Service Object may not save the objects it gets passed into the `#call` method to the database. Following this rule, you can call several Service Object in a row without worrying to save an object too soon or multiple times.

* However, a Service Object may create other persistence objects and save them to the database.

* The `#call` method (which is called by the `.call` class method) should return a truthy value when the execution was successful and `false` otherwise.




## Contributing

1. Fork it ( http://github.com/<my-github-username>/prime_service/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
