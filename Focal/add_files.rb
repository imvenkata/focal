require 'xcodeproj'

project_path = '../Focal.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Views/Navigation group
views_group = project.main_group['Focal']['Views']
navigation_group = views_group['Navigation']

# Add FABButton.swift
fab_file = navigation_group.new_file('Navigation/FABButton.swift')
project.targets[0].add_file_references([fab_file])

# Find the Views/Components group
components_group = views_group['Components']

# Add new component files
empty_interval = components_group.new_file('Components/EmptyIntervalView.swift')
subtask_row = components_group.new_file('Components/SubtaskRow.swift')

project.targets[0].add_file_references([empty_interval, subtask_row])

project.save
puts "Added files to Xcode project"
