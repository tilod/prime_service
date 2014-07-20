# PrimeService

A gem for Service Objects.




# Installation

Add this line to your application's Gemfile:

    gem 'prime_service'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prime_service




# Usage

A service object encapsulates a complex manipulation.



## Defining a service object


### A simple service

The `.call_with` macro method defines attribute readers and writers named by the passed symbols. When you call the service, pass these attributes as arguments.

The core functionality of the service is provided by the `#call` method.


```ruby
class MarkMessageAsRead < PrimeService::Service
  call_with :message

  def call
    message.read = true
    message.save!
    
    true
  end
end
```

By convention the service should return a truthy value if it succeded and `false` if an error occured. In the above example, this is done by returning `true` if no exception was thrown by the `#save!` method. It is also possible to use `#save` and return directly after the method call. Either way, error handling must be implemented manually.



### A service with a factory method

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
      message.save!
      
      true
    end
  end

  class WithNotification < self
    def call
      SendReadNotification.call(message)
      message.read = true
      message.save!
      
      true
    end
  end
end
```


## Calling the Service Object

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

Mark a message as read.

```ruby
class MessagesController < ApplicationController
  def mark_as_read
    message = Message.find(params[:id])
    MarkMessageAsRead.call(message)

    redirect_to messages_path
  end
end
```

Sharing a message on Twitter. If sharing on Twitter fails, the message should not be created.

```ruby
class MessagesController < ApplicationController
  def create
    @messages = Message.new(params[:message])

    if ShareMessageOnTwitter.call(@message)
      redirect_to @message
    else
      render "new"
    end
  end
end
```



## Contributing

1. Fork it ( http://github.com/<my-github-username>/prime_service/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
