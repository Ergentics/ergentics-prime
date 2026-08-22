public enum PrimeEmbeddedBuildProvenance {
    #if DEBUG
        public static let buildConfiguration = "debug"
    #else
        public static let buildConfiguration = "release"
    #endif

    // This file is excluded only to avoid a self-referential digest. Runtime
    // verification requires this exact canonical template and digest; every
    // other admitted package, source, test, and architecture file is hashed.
    public static let sourceIdentitySHA256 =
        "fad7e1e0d61da7f0519dba00b6c5c3f644f5d389a2e4f8a5ac4ca937c99cfc9d"
}
