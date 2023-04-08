{
  serviceName,
  config,

  lib,
  writeText,
  substituteAll,
  runCommand,

  shadowsocks_teapot,
  cue,
}:

rec {

  configCue = substituteAll {
    src = ./server.cue;
    inherit ( config )
      dns_addr
      ss_port_a
      ss_port_b
      ss_password;
  };

  configFile = runCommand "server.json" {} ''
    ${lib.getExe cue} export ${configCue} -o "$out"
  '';

  service = writeText "${serviceName}-shadowsocks.service" ''
    [Unit]
    Description = shadowsocks
    After = network-online.target
    Wants = network-online.target

    [Service]
    Type = simple
    ExecStart = ${shadowsocks_teapot}/bin/ssserver --config ${configFile}
    Restart = on-failure

    [Install]
    WantedBy = multi-user.target
  '';

}
