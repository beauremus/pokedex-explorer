{ pkgs ? import <nixpkgs> {} }:

let
  # Check available versions with: nix-env -qaP 'ruby'
  rubyVersion = pkgs.ruby;
  rubyEnv = rubyVersion.withPackages (ps: with ps; [
    rails
  ]);
in 
pkgs.mkShell {
  # buildInputs are the packages needed in the environment
  buildInputs = with pkgs; [
    # --- Ruby Environment ---
    # Choose a Ruby version available in your nixpkgs channel
    rubyEnv

    # --- JavaScript Environment (Required by Rails) ---
    # Node.js is needed for the asset pipeline or JS bundling (Webpacker/Shakapacker)
    nodejs # Specify a version like 18, 20, etc., or just 'nodejs'

    # Yarn is often used by Rails for JS package management
    yarn

    # --- Database ---
    # SQLite C library needed by the 'sqlite3' Ruby gem
    sqlite

    # --- Optional but Recommended ---
    # Git for version control (if not already globally available)
    git

    # Build tools sometimes needed for gems with native C extensions
    gcc
    gnumake
    pkg-config # Often needed to find libraries like sqlite
    libyaml
  ];

  # You can set environment variables here if needed later
  # shellHook = ''
  #   echo "Entered Nix shell for Pokedex Explorer!"
  #   export PGHOST="localhost" # Example
  # '';
}
