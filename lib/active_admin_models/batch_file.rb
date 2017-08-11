ActiveAdmin.register BatchFile do
  menu parent: "Payment", label: "Batch", priority: 2
  actions :index
  config.sort_order = 'updated_at_desc'
  collection_action :test, method: :post do
    begin
      s = UploadService.new
      s.test
      flash[:notice] = "Everything ok, we could connect and the folder exists :-)"
    rescue => e
      flash[:error] = "Test failed: #{e}"
    end
    redirect_to({:action => :index})
  end

  member_action :upload, method: :post do
    begin
      batch = BatchFile.find(params[:id])
      s = UploadService.new
      s.process(batch)
      flash[:notice] = "Successfully uploaded."
    rescue => e
      flash[:error] = "Upload failed: #{e}"
    end
    redirect_to({:action => :index})
  end

  index do
    column :message_id
    column :created_at
    column :uploaded_at
    column :link do |f|
      link_to f.message_id, download_batch_file_url(f)
    end
    column :upload do |f|
      link_to('Upload', upload_admin_batch_file_url(f), method: :post) unless f.uploaded?
    end
    actions
  end

  sidebar "Postfinance server", only: [:index] do
    ul do
      li "host: #{ENV['POSTFINANCE_HOST']}"
      li "user: #{ENV['POSTFINANCE_USER']}"
      li "folder: #{ENV['POSTFINANCE_FOLDER_IN']}"
      li "key: #{ENV['POSTFINANCE_KEY'].blank?? "not ok": "ok"}"
      li link_to "Test", test_admin_batch_files_path, method: :post
    end

  end

end
