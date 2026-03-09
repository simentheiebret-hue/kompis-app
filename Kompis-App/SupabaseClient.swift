//
//  SupabaseClient.swift
//  Kompis-App
//
//  Created by Claude on 23/02/2026.
//

import Supabase
import Foundation

let supabase = SupabaseClient(
    supabaseURL: URL(string: Config.supabaseURL)!,
    supabaseKey: Config.supabaseKey
)
