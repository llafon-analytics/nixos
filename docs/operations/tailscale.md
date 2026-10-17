# Tailscale

Le service est activé dans `modules/nixos/network.nix` (`services.tailscale`, avec `--ssh`).

## Politique réseau

Tous les ports de service des deux machines sont ouverts **uniquement sur l'interface
`tailscale0`** (voir [Ports](../reference/ports.md)). Seuls restent ouverts sur le réseau local :
UDP 41641 (connexions directes Tailscale), mDNS et KDE Connect.

Si Tailscale est arrêté, les services ne sont plus joignables à distance ; l'accès local à la
machine n'est pas affecté.

## Joindre le tailnet

```sh
sudo tailscale up --auth-key=<VOTRE_CLE>
```

Le nom de la machine dans le tailnet suit le hostname (`desktop`, `laptop`).

## Vérifier l'état

```sh
systemctl status tailscaled
tailscale status
```

## À compléter

- Politique d'expiration des clés.
- Paramètres optionnels (`--accept-routes`, tags…) selon vos besoins.
