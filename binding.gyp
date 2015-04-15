{
  "targets":[
    {
      "target_name":"addon",
      "sources":["src/addon.cc", "src/node_nodave.cc"],
      "include_dirs": [
        "<!(node -e \"require('nan')\")"
      ],
      "dependencies": [
        'src/libnodave/libnodave.gyp:nodave'
      ]
    }
  ]
}
