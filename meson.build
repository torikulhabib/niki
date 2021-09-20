project('com.github.torikulhabib.niki', 'vala', 'c', version: '1.0.0')
vapi = join_paths(meson.current_source_dir(), 'vapi')
gnome = import('gnome')
i18n = import('i18n')
add_project_arguments(['-DGETTEXT_PACKAGE="' + meson.project_name() + '"'.format(meson.project_name())], language: 'c',)
add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"'.format (meson.project_name()), language:'c')
add_global_arguments('-DPACKAGE="' + meson.project_name() + '"'.format (meson.project_name()), language:'c')
add_global_arguments('-DVERSION="' + meson.project_name() + '"'.format (meson.project_name()), language:'c')
add_project_arguments(['--vapidir', vapi], language: 'vala')

conf = configuration_data()
conf.set('EXEC_NAME', meson.project_name())
conf.set_quoted('PROJECT_NAME', meson.project_name())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('PREFIX', get_option('prefix'))
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PACKAGE', meson.project_name())

zlib_dep = dependency('zlib', required : false)
if not zlib_dep.found()
  zlib_dep = cc.find_library('z', required : false)
  if not zlib_dep.found() or not cc.has_header('zlib.h')
    zlib_dep = subproject('zlib').get_variable('zlib_dep')
  endif
endif
conf.set('HAVE_ZLIB', true)

asresources = gnome.compile_resources(
    'as-resources', 'data/com.github.torikulhabib.niki.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

configure_file(output: 'config.h', configuration: conf)

c_args = [
  '-include', 'config.h', '-w', '-DGETTEXT_PACKAGE="' + meson.project_name() + '"'
]

subdir('src')
subdir('data')
subdir('po')
meson.add_install_script('meson/post_install.py')
