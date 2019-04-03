require 'azure/storage/file'
require 'json'

@storage_acount_name = ''
@storage_account_key = ''

def storage_account
  puts 'Getting list of storage accounts'
  command = `az storage account list -g ${azure_resource_group_name}`
  storage_accounts = JSON.parse(command).collect {|a| a['name']}
  storage_accounts.each do | sa |
    puts "Checking #{sa} for our share"
    command = `az storage share list --account-name "#{sa}"`
    JSON.parse(command).each do | share |
      if share['name'] == '${share_name}'
        puts "Setting the login variables"
        command = `az storage account keys list -g ${azure_resource_group_name} -n "#{sa}"`
        @storage_account_name = sa
        @storage_account_key = JSON.parse(command).first['value']
      end
    end
  end
end

def setup_client 
  @client = Azure::Storage::File::FileService.create(
  storage_account_name: "#{@storage_account_name}", 
  storage_access_key: "#{@storage_account_key}",
  default_endpoints_protocol: 'https'
  )
end

def create_directory
  puts 'Creating direcotory'
  directory = @client.create_directory('${share_name}', 'solr_config')
  directory
rescue StandardError  
  directory = @client.get_directory_metadata('${share_name}', 'solr_config')
end

def create_files(directory)
  puts 'Creating files'
  Dir.glob("../solr/config/*").each do | f |
    if File.file?(f)
      content = ::File.open(f, 'rb') { |file| file.read }
      file = @client.create_file('${share_name}', directory.name, File.basename(f), content.size)
      @client.put_file_range('${share_name}', directory.name, file.name, 0, content.size - 1, content)
    end
  end
rescue StandardError => e  
  puts e.message
end

storage_account
setup_client
directory = create_directory
create_files(directory)