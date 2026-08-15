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
        "026ac33c426c8368e3eecfc327637580590b580c9b094af7aef61a7158c9906a"
}
