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
        "770c59846ab339b1150bec2f4a14aae763dd2c1a97b06184d54138c96b3752a3"
}
