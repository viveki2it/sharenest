ActiveAdmin.register IpAddress do
  csv do
    column :id
    column :address
    column :count
    column :created_at
    column :updated_at
  end

  actions :index, :show, :destroy
  
  index download_links: [:csv] do
    column :id
    column :address
    column :count
    column :created_at
    column :updated_at
    actions
  end
  
end
