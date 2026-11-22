# Adds the UntisPlusWidget WidgetKit extension to Runner.xcodeproj, so nobody needs Xcode.
# CI runs it before every iOS build; it does nothing if the target already exists.
require 'xcodeproj'

NAME = 'UntisPlusWidget'
project = Xcodeproj::Project.open(File.expand_path('../Runner.xcodeproj', __dir__))
if project.targets.any? { |t| t.name == NAME }
  puts "#{NAME} already exists"
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' }
app_id = runner.build_configurations.first.build_settings['PRODUCT_BUNDLE_IDENTIFIER']

widget = project.new_target(:app_extension, NAME, :ios, '16.0')
widget.add_build_configuration('Profile', :release) unless widget.build_configurations.any? { |c| c.name == 'Profile' }

group = project.main_group.new_group(NAME, NAME)
widget.add_file_references([group.new_reference('UntisPlusWidget.swift')])
group.new_reference('Info.plist')
group.new_reference("#{NAME}.entitlements")

widget.build_configurations.each do |config|
  runner_config = runner.build_configurations.find { |c| c.name == config.name }
  # Flutter's xcconfig provides FLUTTER_BUILD_NAME/NUMBER for the version in Info.plist.
  config.base_configuration_reference = runner_config.base_configuration_reference
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = "#{app_id}.#{NAME}"
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = "#{NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_ENTITLEMENTS'] = "#{NAME}/#{NAME}.entitlements"
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

runner.add_dependency(widget)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
embed.add_file_reference(widget.product_reference, true).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
# Before Flutter's "Thin Binary" script phase, or Xcode reports a dependency cycle.
runner.build_phases.delete(embed)
thin = runner.build_phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } || runner.build_phases.length
runner.build_phases.insert(thin, embed)

runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

project.save
puts "Added #{NAME} (#{app_id}.#{NAME})"
