_:

{
  # Local, network (driverless IPP/AirPrint) and USB printing.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.ipp-usb.enable = true;
}
