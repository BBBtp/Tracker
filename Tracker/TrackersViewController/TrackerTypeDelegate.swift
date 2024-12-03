//
//  TrackerTypeDelegate.swift
//  Tracker
//
//  Created by Богдан Топорин on 31.10.2024.
//

protocol TrackerTypeDelegate: AnyObject {
   func didSelectTrackerType(tracker: TrackerModel, category: String)
}


