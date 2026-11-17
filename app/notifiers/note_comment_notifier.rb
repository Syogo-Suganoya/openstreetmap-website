# frozen_string_literal: true

class NoteCommentNotifier < ApplicationNotifier
  recipients -> { record.notifiable_subscribers }

  validates :record, :presence => true

  notification_methods do
    # Matches the note page and the comments shown on it
    def record_visible?
      return false unless record.author.nil? || record.author.active?

      recipient.moderator? || (record.note.visible? && record.visible?)
    end
  end

  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = "note_comment_notification"
    config.if = -> { recipient.notification_preferences.note_comment.include?("email") }
  end
end
