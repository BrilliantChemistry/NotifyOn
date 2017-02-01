require 'rails_helper'

RSpec.describe Comment, type: :model do

  let(:comment) { create(:comment) }

  it 'updates the original notification within the appropriate scope' do
    comment
    n = comment.notifications.first
    expect(notification_count).to eq(1)
    # This should update the notification.
    create(:comment, :user => comment.user, :post => comment.post)
    expect(notification_count).to eq(1)
    # This does not apply to the update -- a new notification is created.
    create(:comment, :post => comment.post)
    expect(notification_count).to eq(2)
    # Nor does this -- a new notification is created.
    create(:comment, :user => comment.user)
    expect(notification_count).to eq(3)
  end

end
