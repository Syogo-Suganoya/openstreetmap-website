# frozen_string_literal: true

class ApplicationNotifier < Noticed::Event
  notification_methods do
    def record_required?
      true
    end

    # Whether the recipient may still see the record. Notifiers whose
    # records can be hidden override this to match the record's own page.
    def record_visible?
      true
    end
  end
end
