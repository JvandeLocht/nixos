{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wofi;
in {
  options.wofi = {
    enable = mkEnableOption "Wofi application launcher";
    style = mkOption {
      type = types.lines;
      default = "";
      description = "CSS style for Wofi";
    };
  };

  config = mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      style = ''
        * {
          font-family: "Hack", monospace;
        }

        window {
          background-color: #3B4252;
        }

        #input {
          margin: 5px;
          border-radius: 0px;
          border: none;
          background-color: #3B4252;
          color: white;
        }

        #inner-box {
          background-color: #383C4A;
        }

        #outer-box {
          margin: 2px;
          padding: 10px;
          background-color: #383C4A;
        }

        #scroll {
          margin: 5px;
        }

        #text {
          padding: 4px;
          color: white;
        }

        #entry:nth-child(even){
          background-color: #404552;
        }

        #entry:selected {
          background-color: #4C566A;
        }

        #text:selected {
          background: transparent;
        }
      '';
    };
  };
}
# {
#   lib,
#   config,
# }: {
#   options = {
#     wofi.enable =
#       lib.mkEnableOption "enables wofi with custom config";
#   };
#
#   config = lib.mkIf config.wofi.enable {
#     programs.wofi = {
#       enable = true;
#       style = ''
#         * {
#         	font-family: "Hack", monospace;
#         }
#
#         window {
#         	background-color: #3B4252;
#         }
#
#         #input {
#         	margin: 5px;
#         	border-radius: 0px;
#         	border: none;
#         	background-color: #3B4252;
#         	color: white;
#         }
#
#         #inner-box {
#         	background-color: #383C4A;
#         }
#
#         #outer-box {
#         	margin: 2px;
#         	padding: 10px;
#         	background-color: #383C4A;
#         }
#
#         #scroll {
#         	margin: 5px;
#         }
#
#         #text {
#         	padding: 4px;
#         	color: white;
#         }
#
#         #entry:nth-child(even){
#         	background-color: #404552;
#         }
#
#         #entry:selected {
#         	background-color: #4C566A;
#         }
#
#         #text:selected {
#         	background: transparent;
#         }
#       '';
#     };
#   };
# }
