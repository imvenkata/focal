require 'xcodeproj'

project_path = '../Focal.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets[0]

# Files we're managing  
ai_files = ['LLMProvider.swift', 'LLMError.swift', 'LLMService.swift']
utility_files = ['KeychainManager.swift']
all_files = ai_files + utility_files

puts "Cleaning up..."

# Remove ALL build file references for our files
all_files.each do |filename|
  target.source_build_phase.files.select { |bf| bf.file_ref&.display_name == filename }.each(&:remove_from_project)
end

# Remove all matching file refs recursively
def remove_files_from_group(group, filenames)
  group.files.select { |f| filenames.include?(f.display_name) }.each(&:remove_from_project)
  group.groups.each { |g| remove_files_from_group(g, filenames) }
end
remove_files_from_group(project.main_group, all_files)

# Remove any AI groups under Services  
services_group = project.main_group['Focal']['Services']
services_group.groups.select { |g| g.display_name == 'AI' }.each(&:remove_from_project)

project.save
puts "Cleanup done!"

# Reopen fresh
project = Xcodeproj::Project.open(project_path)
target = project.targets[0]

# Get groups
focal_group = project.main_group['Focal']
services_group = focal_group['Services']
utilities_group = focal_group['Utilities']

# Create AI group WITHOUT a path (just name, like Services group itself)
# AI group will be a virtual group, files will have full path from Focal
ai_group = services_group.new_group('AI')  # No path argument

# Add AI files with full path from Focal group (matching existing Services files pattern)
# e.g., TaskNotificationService has path = "Services/TaskNotificationService.swift"
ai_files.each do |filename|
  file_ref = project.new(Xcodeproj::Project::Object::PBXFileReference)
  file_ref.name = filename
  file_ref.path = "Services/AI/#{filename}"  # Full path from Focal
  file_ref.source_tree = '<group>'
  file_ref.last_known_file_type = 'sourcecode.swift'
  file_ref.include_in_index = '1'
  ai_group << file_ref
  target.source_build_phase.add_file_reference(file_ref)
  puts "  Added Services/AI/#{filename}"
end

# Add KeychainManager - Utilities group has path "Utilities" so just filename works
keychain_ref = utilities_group.new_file('KeychainManager.swift')
target.source_build_phase.add_file_reference(keychain_ref)
puts "  Added Utilities/KeychainManager.swift"

project.save
puts "Done!"
