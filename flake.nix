{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      perSystem = {pkgs, ...}: {
        devShells.default = inputs.devenv.lib.mkShell {
          inherit pkgs inputs;
          modules = [
            ({config, ...}: rec {
              name = "wp";

              packages = [pkgs.wp-cli pkgs.yarn];

              # dotenv.enable = true;

              env.APP_NAME = "tecmobat";
              env.WP_ENV = "development";
              env.WP_HOME = "http://localhost:8080";
              env.WP_SITEURL = "${env.WP_HOME}/wp";

              env.AUTH_KEY = "kBAPVd:|G9u3y?k<0d&}sJI93=<?acqb]JivOe)RlAf&GRcx|iHZ&vx!ktEd81L^";
              env.SECURE_AUTH_KEY = "=A5}4g-J5la<)uVo_8{FmE<nz7&LKy60BJznwb:@D3dE>ldq=QdwyzcwF0_2p:]9";
              env.LOGGED_IN_KEY = "-Rbn+;njH1S(:o/]/#Ul0hrVaa6:4WRLP|;n&osRgVMA-vGBJ./6Y`1,3W$W}5ad";
              env.NONCE_KEY = "Tw9nKYir];*vKdd<iqQksYGAnvu>S3@s}_/n2QE}l-[?LZ<JF]ISUI!m3j_(]en{";
              env.AUTH_SALT = "0pn9v^H;qwt}Typ=m5}*PRf@-v8(W:)B)Xx3+^A#bb7&TJsC}akD+?z!v*QKT941";
              env.SECURE_AUTH_SALT = "/q]_Mz}l|y{Ra/G9*nG%tX9L_x.?,]&XLVP&jNKUAUq>/5:IpO@87Or/2VVYgzQc";
              env.LOGGED_IN_SALT = "mmQ=5U}Mg->oe)czW{{bsL>>]|EB?ii5Gs0%SI:aT(NuT]cF3Aq=nHE!$*<c`Jbq";
              env.NONCE_SALT = "SK&(tt$O1R6qk`$UO3h9OL)Exy}x|W%sA&l|l+l7v`bt9eTrw:?xgBH)_UTc*NX9";

              env.DB_NAME = "wordpress";
              env.DB_PASSWORD = "password";
              env.DB_HOST = "0.0.0.0";
              env.DB_USER = "${env.APP_NAME}";

              # services.nginx.enable = true;
              # services.nginx.httpConfig = ''
              #   gzip on;

              #   server {
              #       listen 3000;
              #       listen [::]:3000;
              #       server_name localhost www.localhost;

              #       location / {
              #           try_files $uri @srv;
              #       }

              #       location @srv {
              #           proxy_set_header X-Real-IP  $remote_addr;
              #           proxy_set_header X-Forwarded-For $remote_addr;
              #           proxy_set_header X-Forwarded-Proto $scheme;
              #           proxy_set_header Host $host;
              #           proxy_pass http://localhost:8080;
              #       }
              #     }
              # '';

              services.mysql.enable = true;
              services.mysql.package = pkgs.mariadb;
              services.mysql.initialDatabases = [{name = "wordpress";}];
              services.mysql.ensureUsers = [
                {
                  name = "${env.APP_NAME}";
                  password = "password";
                  ensurePermissions = {
                    "*.*" = "ALL PRIVILEGES";
                  };
                }
              ];

              languages.javascript.enable = true;
              languages.php.enable = true;
              languages.php.package = pkgs.php82.buildEnv {
                extensions = {
                  all,
                  enabled,
                }:
                  with all; enabled ++ [];
                extraConfig = ''
                  memory_limit = 256m
                '';
              };

              # certificates = ["localhost:3000" "*.localhost:3000"];
              # hosts = {
              #   "localhost" = "127.0.0.1";
              # };

              processes.wp-server.exec = "${pkgs.wp-cli}/bin/wp server";
              # processes.dev.exec = "${pkgs.nodePackages.yarn}/bin/yarn dev";
            })
          ];
        };
      };
    };
}
