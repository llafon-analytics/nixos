{ ... }:

{
  security.polkit.enable = true;
  # Realtime scheduling for low-latency processes (PipeWire).
  security.rtkit.enable = true;

  services.dbus.enable = true;
  services.udisks2.enable = true;
  services.logrotate.checkConfig = false;

  # Release the system was first installed with. Never bump it casually: it
  # pins stateful defaults (databases, data directories), not package versions.
  system.stateVersion = "23.05";
}
