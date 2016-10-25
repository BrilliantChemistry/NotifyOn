require 'rails_helper'

RSpec.describe Post, type: :model do

  let(:post) { create(:post) }

  context 'creates a notification that' do
    let(:post) { create(:post, :state => :draft) }
    it 'does not create a notification on create' do
      post
      expect(notification_count).to eq(0)
    end
    it 'does not create a notification when changing to "pending"' do
      post.pending!
      expect(notification_count).to eq(0)
    end
    it 'creates a notification when changing to "published"' do
      post.published!
      expect(notification_count).to eq(1)
    end
  end

end
