{
  description = "PySpark dev/testing environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        python = pkgs.python311;

        pythonEnv = python.withPackages (ps: [
          ps.pyspark
          ps.pytest
          ps.ipython
        ]);

        spark = pkgs.spark;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
            spark
            pkgs.openjdk17
          ];

          env = {
            SPARK_HOME = spark;
            JAVA_HOME = pkgs.openjdk17;
            PYSPARK_PYTHON = "${pythonEnv}/bin/python";
          };

          shellHook = ''
            export PATH="$SPARK_HOME/bin:$PATH"
            echo "PySpark dev environment ready"
          '';
        };
      }
    );
}

