# Export to CSV with the referrer_id
ActiveAdmin.register User do
  filter :id
  filter :email
  filter :referral_code
  filter :referrer_id
  filter :created_at
  filter :updated_at

  csv do
    column :id
    column :email
    column :referral_code
    column :referrer_id
    column "referrals count" do |user|
      user.referrals.count  
    end
    column "Referral emails" do |user|
      user.referrals.map(&:email).join(',')
    end
    column :created_at
    column :updated_at
  end

  actions :index, :edit, :show, :destroy, :update
  
  index download_links: [:csv] do
    column :id
    column :email
    column :referral_code
    column :referrer_id
    column "Referrals Count" do |user|
      user.referrals.count  
    end
    column :created_at
    column :updated_at
    column "View Referrals" do |user|
      link_to("Link", user.user_url(root_url), target: '_blank')
    end    
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :email
      if f.object.new_record?
        f.input :referrer_id, as: :select, collection: User.all.map {|user| [user.email, user.id]}
      else
        f.input :referrer_id, as: :select, collection: User.all.map {|user| [user.email, user.id]}, selected: f.object.referrer_id
      end
      f.input :referral_code, as: :hidden
    end
    f.actions
  end  

end
