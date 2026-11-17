# frozen_string_literal: true

class DiaryCommentNotifier < ApplicationNotifier
  recipients -> { record.notifiable_subscribers }

  validates :record, :presence => true

  notification_methods do
    # Matches the diary entry page and the comments shown on it
    def record_visible?
      entry = record.diary_entry
      can_unhide = recipient.moderator? || recipient.administrator?

      return false unless entry.user.active?
      return false unless entry.visible? || entry.user == recipient || can_unhide

      can_unhide || (record.visible? && record.user.active?)
    end
  end

  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = "diary_comment_notification"
    config.if = -> { recipient.notification_preferences.diary_comment.include?("email") }
  end
end
