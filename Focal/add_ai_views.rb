require 'xcodeproj'

project_path = '../Focal.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets[0]

focal_group = project.main_group['Focal']
views_group = focal_group['Views']

# Find or create AI group under Views
ai_views_group = views_group['AI']
if ai_views_group.nil?
  ai_views_group = views_group.new_group('AI', 'AI')
  puts "Created Views/AI group"
else
  puts "Views/AI group already exists"
end

# Files to add
ai_view_files = [
  'AIOnboardingView.swift',
  'AIQuickAddBar.swift',
  'BrainDumpView.swift',
  'AISettingsView.swift'
]

ai_view_files.each do |filename|
  # Check if file already exists in group
  existing = ai_views_group.files.find { |f| f.display_name == filename }
  if existing.nil?
    file_ref = ai_views_group.new_file(filename)
    target.source_build_phase.add_file_reference(file_ref)
    puts "  Added #{filename}"
  else
    puts "  #{filename} already exists"
  end
end

project.save
puts "Done!"
