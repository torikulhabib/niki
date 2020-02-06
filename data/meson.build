icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: meson.project_name() + '.svg'
    )
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: meson.project_name() + '.svg'
    )
endforeach

actions = [
    '.fullscreen-symbolic.svg',
    '.unfullscreen-symbolic.svg',
    '.next-symbolic.svg',
    '.previous-symbolic.svg',
    '.replay-symbolic.svg',
    '.subtittle-on-symbolic.svg',
    '.subtittle-off-symbolic.svg',
    '.play-symbolic.svg',
    '.pause-symbolic.svg',
    '.equalizer-on-symbolic.svg',
    '.liric-off-symbolic.svg',
    '.liric-on-symbolic.svg',
    '.playlist-symbolic.svg',
    '.folder-symbolic.svg',
    '.remove-symbolic.svg',
    '.video-filter-on-symbolic.svg',
    '.auto-symbolic.svg',
    '.refresh-right-symbolic.svg',
    '.refresh-left-symbolic.svg',
    '.refresh-180-symbolic.svg',
    '.video-device-symbolic.svg',
    '.record-symbolic.svg',
    '.recording-symbolic.svg',
    '.capture-symbolic.svg',
    '.info-hide-symbolic.svg',
    '.flip-on-symbolic.svg',
    '.flip-off-symbolic.svg',
    '.timer-off-symbolic.svg',
    '.timer-3-symbolic.svg',
    '.timer-5-symbolic.svg',
    '.flash-off-symbolic.svg',
    '.flash-on-symbolic.svg',
    '.title-symbolic.svg',
    '.ascending-symbolic.svg',
    '.descending-symbolic.svg',
]

foreach m : actions
    install_data(
        join_paths('icons', 'actions', meson.project_name() + m),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '16x16' , 'apps')
    )
    install_data(
        join_paths('icons', 'actions', meson.project_name() + m),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '24x24' , 'apps')
    )
    install_data(
        join_paths('icons', 'actions', meson.project_name() + m),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32' , 'apps')
    )
    install_data(
        join_paths('icons', 'actions', meson.project_name() + m),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '48x48' , 'apps')
    )

endforeach

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

i18n.merge_file(
    input:  meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)
i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)
desktop_file_validate = find_program('desktop-file-validate', required:false)
