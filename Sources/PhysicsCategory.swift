// Sources/PhysicsCategory.swift
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0
    static let enemy: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let fireball: UInt32 = 0x1 << 3
    static let healthItem: UInt32 = 0x1 << 4  // Add this
    static let shieldItem: UInt32 = 0x1 << 5  // Add this
}
