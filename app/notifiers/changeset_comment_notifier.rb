# frozen_string_literal: true

class ChangesetCommentNotifier < ApplicationNotifier
  recipients -> { record.notifiable_subscribers }

  validates :record, :presence => true

  notification_methods do
    # Matches the comments shown on the changeset page
    def record_visible?
      record.visible? || recipient.moderator?
    end
  end

  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = "changeset_comment_notification"
    config.if = -> { recipient.notification_preferences.changeset_comment.include?("email") }
  end
end
