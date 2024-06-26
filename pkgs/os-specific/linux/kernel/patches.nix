{ lib, fetchpatch, fetchurl }:

{
  ath_regd_optional = rec {
    name = "ath_regd_optional";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://github.com/openwrt/openwrt/raw/ed2015c38617ed6624471e77f27fbb0c58c8c660/package/kernel/mac80211/patches/ath/402-ath_regd_optional.patch";
      sha256 = "1ssDXSweHhF+pMZyd6kSrzeW60eb6MO6tlf0il17RC0=";
      postFetch = ''
        sed -i 's/CPTCFG_/CONFIG_/g' $out
        sed -i '/--- a\/local-symbols/,$d' $out
      '';
    };
  };

  bridge_stp_helper =
    { name = "bridge-stp-helper";
      patch = ./bridge-stp-helper.patch;
    };

  # Reverts the buggy commit causing https://bugzilla.kernel.org/show_bug.cgi?id=217802
  dell_xps_regression = {
    name = "dell_xps_regression";
    patch = fetchpatch {
      name = "Revert-101bd907b424-misc-rtsx-judge-ASPM-Mode-to-set.patch";
      url = "https://raw.githubusercontent.com/openSUSE/kernel-source/1b02b1528a26f4e9b577e215c114d8c5e773ee10/patches.suse/Revert-101bd907b424-misc-rtsx-judge-ASPM-Mode-to-set.patch";
      sha256 = "sha256-RHJdQ4p0msTOVPR+/dYiKuwwEoG9IpIBqT4dc5cJjf8=";
    };
  };

  request_key_helper =
    { name = "request-key-helper";
      patch = ./request-key-helper.patch;
    };

  request_key_helper_updated =
    { name = "request-key-helper-updated";
      patch = ./request-key-helper-updated.patch;
    };

  modinst_arg_list_too_long =
    { name = "modinst-arglist-too-long";
      patch = ./modinst-arg-list-too-long.patch;
    };

  hardened = let
    mkPatch = kernelVersion: { version, sha256, patch }: let src = patch; in {
      name = lib.removeSuffix ".patch" src.name;
      patch = fetchurl (lib.filterAttrs (k: v: k != "extra") src);
      extra = src.extra;
      inherit version sha256;
    };
    patches = lib.importJSON ./hardened/patches.json;
  in lib.mapAttrs mkPatch patches;

  # Adapted for Linux 5.4 from:
  # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=04896832c94aae4842100cafb8d3a73e1bed3a45
  rtl8761b_support =
    { name = "rtl8761b-support";
      patch = ./rtl8761b-support.patch;
    };

  export-rt-sched-migrate = {
    name = "export-rt-sched-migrate";
    patch = ./export-rt-sched-migrate.patch;
  };

  rust_1_75 = {
    name = "rust-1.75.patch";
    patch = ./rust-1.75.patch;
  };

  rust_1_76 = {
    name = "rust-1.76.patch";
    patch = fetchurl {
      name = "rust-1.76.patch";
      url = "https://lore.kernel.org/rust-for-linux/20240217002638.57373-2-ojeda@kernel.org/raw";
      hash = "sha256-q3iNBo8t4b1Rn5k5lau2myqOAqdA/9V9A+ok2jGkLdY=";
    };
  };

  rust_1_77-6_8 = {
    name = "rust-1.77.patch";
    patch = ./rust-1.77-6.8.patch;
  };

  rust_1_77-6_9 = {
    name = "rust-1.77.patch";
    patch = ./rust-1.77.patch;
  };

  rust_1_78 = {
    name = "rust-1.78.patch";
    patch = fetchpatch {
      name = "rust-1.78.patch";
      url = "https://lore.kernel.org/rust-for-linux/20240401212303.537355-4-ojeda@kernel.org/raw";
      excludes = [ "Documentation/process/changes.rst" ]; # Conflicts on 6.8.
      hash = "sha256-EZ+Qa9z1AtAv08e72M7BEsCZi9UK572gmW+AR62a8EM=";
    };
  };
}
