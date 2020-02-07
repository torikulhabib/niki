# project name and programming language
project('com.github.torikulhabib.niki', 'vala', 'c', version: '1.0.0')

gnome = import('gnome')
i18n = import('i18n')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')
add_project_arguments(['-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())], language: 'c',)
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

conf = configuration_data()
conf.set('EXEC_NAME', meson.project_name())
conf.set_quoted('PROJECT_NAME', meson.project_name())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('PREFIX', get_option('prefix'))
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PACKAGE', meson.project_name())
conf.set_quoted('LOCALE_DIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('PKGDATADIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))

asresources = gnome.compile_resources(
    'as-resources', 'data/com.github.torikulhabib.niki.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

configure_file(
  output: 'config.h',
  configuration: conf
)
config_h_dir = include_directories('src')

c_args = [
  '-include', 'config.h',
  '-w', '-DGETTEXT_PACKAGE="' + meson.project_name() + '"'
]
subdir('src')
subdir('data')
subdir('po')
meson.add_install_script('meson/post_install.py')
