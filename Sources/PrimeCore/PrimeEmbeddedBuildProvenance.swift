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
        "0d885101ce662587456fcde41d6f5f6e204d163c9c4d6a7f9b16551cd049b807"
}
