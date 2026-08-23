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
        "74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2"
}
