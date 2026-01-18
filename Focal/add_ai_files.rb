require 'xcodeproj'

project_path = '../Focal.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets[0]

# Remove the incorrectly added AIModels.swift
puts "Cleaning up AIModels.swift..."
target.source_build_phase.files.select { |bf| bf.file_ref&.display_name == 'AIModels.swift' }.each(&:remove_from_project)

# Remove from AI group under Models
focal_group = project.main_group['Focal']
models_group = focal_group['Models']
ai_models_group = models_group['AI']
if ai_models_group
  ai_models_group.files.each(&:remove_from_project)
  ai_models_group.remove_from_project
  puts "  Removed AI group"
end

project.save

# Reopen and add correctly
project = Xcodeproj::Project.open(project_path)
target = project.targets[0]

focal_group = project.main_group['Focal']
models_group = focal_group['Models']

# Create new AI group with path 'AI' (relative to Models which has path 'Models')
# This will correctly resolve to Focal/Models/AI
ai_models_group = models_group.new_group('AI', 'AI')
puts "  Created Models/AI group (with path=AI)"

# Add AIModels.swift with just the filename as path (relative to AI group which is at Models/AI)
file_ref = ai_models_group.new_file('AIModels.swift')
target.source_build_phase.add_file_reference(file_ref)
puts "  Added AIModels.swift"

project.save
puts "Done!"
