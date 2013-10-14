{
  'targets': [
    {
      'target_name': 'nodave',
      'product_prefix': 'lib',
      'type': 'static_library',
      'sources': [
        'nodave.c'
      ],
      'defines': [
        'LINUX',
        'DAVE_LITTLE_ENDIAN'
      ],
      'include_dirs': [
        '.',
      ],
      'direct_dependent_settings': {
        'include_dirs': [
          '.',
        ],
      },
    }
  ]
}
