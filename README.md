NotifyOn
==========

**WARNING: This branch is the bleeding edge. This documentation is in progress, and the code within this branch is not ready for production.**

NotifyOn generates automatic notifications as a result of state changes on a particular model in a Rails application. It supports email messages, along with third-party real-time delivery, while also storing each notification in your database so you can use, adjust, and display as you'd wish.

Getting Started
----------

This gem is built for Ruby on Rails projects. Add it to your Gemfile:

```ruby
gem 'notify_on'
```

Then run the bundle command to install it.

Most of the magic happens behind the scenes. We just need to add two files to your app (`config/initializers/notify_on.rb` and the `NotifyOn::Notification` migration).

```text
$ bundle exec rails g notify_on:install
```

Migrate your database and then you're all set.

Usage
----------

NotifyOn is driven entirely through a `notify_on` call within a model.

### notify_on

```ruby
notify_on(action, options = {})
```

#### Parameters

| Name | Type | Description |
| --- | --- | --- |
| `action` | `symbol` | **Required**. Can be: <ul><li>`:create` to create the notification _after_ an object is created and saved to the database.</li></ul> |
| `options` | `hash` | **Some options are required.** See below for details. |

#### Options

| Name | Type | Description |
| --- | --- | --- |
| `to` | `symbol` | **Required.** Who to send the notification _to_. It **must be a method on the model that triggered the notification**, and it **must have an `email` attribute** if you are are using email notifications. <small>(See note on `to_s` below.)</small> |
| `from` | `symbol` | **Required.** Who the notification is sent _from_. It **must be a method on the model that triggered the notification**, and it **must have an `email` attribute** if you are are using email notifications. <small>(See note on `to_s` below.)</small> |
| `message` | `string` (interpolated) | **Required.** The message that describes the notification itself. <small>(See _String Interpolation_ for more information.)</small> |
| `link` | `array` or `string` (interpolated) | **Required**. Uses Rails' URL helper to generate a reference link for the notification. |
| `email` | `boolean` | (Default: `false`) Whether or not to send an email notification. |
| `template` | `string` or `symbol` | (Default: `nil`) The name of the email template to render. This only applies if `email` is `true` and you wish to override the default mailer. <small>(See _Override Default Email_ for more information.)</small> |
| `pusher` | `hash` | (Default: `nil`) Pusher provides access to real-time notifications. This hash should contain the following: <ul><li>`channel` (interpolated `string`) as the name of the channel</li><li>`event` (`string` or `symbol`) as the name of the Pusher event</li></ul> <small>(See _Pusher_ section for more information.)</small> |

_Note: Many of the defaults within `notify_on` make use of the `to_s` method. It's a good idea to override `to_s` on the models representing your `to` and `from` objects on a notification. Most of the time, this is a `User` object, so your `User` model may have something like this:_

```ruby
def to_s
  name
end
```

#### Example

```ruby
notify_on(
  :create,
  :to => :user,
  :from => :author,
  :message => '{author_email} sent you a message.',
  :email => true,
  :template => 'new_message',
  :link => [:message_path, :self],
  :pusher => { :channel => "presence-message-{id}", :event => :new_message }
)
```

Custom Features
----------

### String Interpolation

NotifyOn has a custom string interpolator for injecting an object's attributes. We can't use Ruby's interpolator because we don't have access to instance methods at the time we define `notify_on`.

The syntax is similar to Ruby's interpolated strings. It just omits the `#` character.

The most important thing to remember is that the variable/method being interpolated is defined on an instance **of the object that triggered the notification**.

For example, you **can't** do something like this:


```ruby
# ...
:message => '{author.email} sent you a message.'
```

But you **can** do this:

```ruby
# ...
:message => '{author_email} sent you a message.'

def author_email
  author.email
end
```

### Dynamic Link Generator

NotifyOn's dynamic link generator helps make your configuration a little simpler. We can't call the the URL helper directly from the `notify_on` call, so we are forced to get a little clever.

We take the components of the URL helper, including its arguments, and add them to an array.

Suppose your notification was on a message. In a view, you might have a route like this:

```ruby
author_message_path(message.author, message)
```

For the `notify_on` config, that would look like this:

```ruby
:link => [:author_message_path, :author, :self]
```

Notice three important pieces here:

1. Every component within the array is a `symbol`, not the direct variable/method.
2. The reference is from the message itself, so we don't use `message.author`, but just `author`.
3. To reference the message, we pass `self` as a symbol.

Unfortunately, we have a few caveats:

1. Non-inferred parameters are not supported. (You can't do something like `:user_id => :author_id`.) If you want to do that, you should use an interpolated string instead of this array-based method.
2. Links are stored on the notification object. If you change your routes, you'll need to update all affected notifications. The easiest way to do this is through a migration.

### Override Default Email

NotifyOn has a very basic email template that uses the description to notify the `to` in your `notify_on` configuration.

You may override this default behavior with a custom email template. You specify this using the `template` option. The view itself goes in `app/views/notifications`.

Within this view, you have access to the notification as `@notification`. From there you can get to the following properties:

- `recipient` is the object that was sent the notification (`to`).
- `sender` is the object that sent the notification (`from`).
- `trigger` is the object that triggered the notification (`self`).
- `description` is the interpolated description for the notification (`message`).
- `link` is the interpolated/converted reference link for the notification (`link`).

### Automatic Associations

NotifyOn automatically attaches an association to the object you specify as `to`. That object (assuming it is inherited from `ActiveRecord::Base`) can access its notifications via `notifications`. For example, if your `to` is represented by `current_user`, then `current_user.notifications` would get you that objects notifications. (It also eager loads the `recipient`, `sender`, and `trigger` associations on the notification to avoid running into `N+1` problems.)

### Pusher (Real-Time Notifications)

[Pusher](https://pusher.com/) is a service that provides a websocket to access real-time information. While it is up to you to configure and support Pusher in your application, NotifyOn helps out a little.

You must specify `pusher` in a `notify_on` configuration. And if you do, you must also add your credentials to `config/initializers/notify_on.rb`. If everything is in place, NotifyOn will trigger an event in Pusher with the `notification` and `trigger`, so you can get any relevant associations.
