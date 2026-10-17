# Tailscale

The service is enabled in `modules/nixos/network.nix` (`services.tailscale`, with `--ssh`).

## Network policy

Every service port of both machines is opened **on the `tailscale0` interface only** (see
[Ports](../reference/ports.md)). Only UDP 41641 (direct Tailscale connections), mDNS and KDE
Connect stay open on the local network.

If Tailscale is down, services are no longer reachable remotely; local access to the machine is
unaffected.

## Join the tailnet

```sh
sudo tailscale up --auth-key=<YOUR_KEY>
```

The machine name in the tailnet follows the hostname (`desktop`, `laptop`).

## Check status

```sh
systemctl status tailscaled
tailscale status
```

## To be completed

- Key expiry policy.
- Optional flags (`--accept-routes`, tags…) as needed.
