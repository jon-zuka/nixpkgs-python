{
  uv2nix, pyproject-build-systems, python311, mkShell, uv, callPackage, pyproject-nix, lib
}:
let
  python = python311;
  
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ../packages/hello-world; }; 
  
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };
  
  pyprojectOverrides = _final: _prev: { };

  pythonSet = (callPackage pyproject-nix.build.packages {
    inherit python;
  }).overrideScope (
    lib.composeManyExtensions [
 #    pyproject-build-systems.overlays.default
      overlay
      pyprojectOverrides
    ]
  );
in {
  devShells = {
    default = mkShell {
      packages = [ python uv ];
      shellHook = ''
        #unset PYTHONPATH
        #export UV_PYTHON_DOWNLOADS=never
      '';
    };
  };
}
