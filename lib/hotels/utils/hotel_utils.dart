import 'package:flutter/material.dart';
import '../models/hotel.dart';

class HotelUtils {
  // Format hotel address for display
  static String formatAddress(Hotel hotel) {
    return hotel.address;
  }

  // Get hotel rating display
  static String formatRating(double? rating) {
    if (rating == null) return 'No rating';
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  // Get hotel status color based on various factors
  static Color getHotelStatusColor(Hotel hotel) {
    if (hotel.rating != null && hotel.rating! >= 4.0) {
      return Colors.green;
    } else if (hotel.rating != null && hotel.rating! >= 3.0) {
      return Colors.orange;
    } else if (hotel.rating != null && hotel.rating! < 3.0) {
      return Colors.red;
    }
    return Colors.grey;
  }

  // Format amenities for display
  static String formatAmenities(List<String>? amenities) {
    if (amenities == null || amenities.isEmpty) {
      return 'No amenities listed';
    }
    if (amenities.length <= 3) {
      return amenities.join(', ');
    }
    return '${amenities.take(3).join(', ')} +${amenities.length - 3} more';
  }

  // Get amenity icon
  static IconData getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
      case 'wi-fi':
        return Icons.wifi;
      case 'pool':
      case 'swimming pool':
        return Icons.pool;
      case 'gym':
      case 'fitness':
      case 'fitness center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'restaurant':
      case 'dining':
        return Icons.restaurant;
      case 'parking':
        return Icons.local_parking;
      case 'conference':
      case 'meeting room':
        return Icons.meeting_room;
      case 'room service':
        return Icons.room_service;      case 'concierge':
        return Icons.support_agent;
      case 'laundry':
        return Icons.local_laundry_service;
      default:
        return Icons.check_circle;
    }
  }

  // Validate hotel data
  static List<String> validateHotelData({
    required String name,
    required String address,
    required String phone,
    required String email,
    String? website,
  }) {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Hotel name is required');
    }

    if (address.trim().isEmpty) {
      errors.add('Hotel address is required');
    }

    if (phone.trim().isEmpty) {
      errors.add('Phone number is required');
    } else if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone)) {
      errors.add('Invalid phone number format');
    }

    if (email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors.add('Invalid email format');
    }

    if (website != null && 
        website.isNotEmpty && 
        !RegExp(r'^https?://').hasMatch(website)) {
      errors.add('Website must start with http:// or https://');
    }

    return errors;
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 10) {
      // Format as (XXX) XXX-XXXX
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      // Format as +1 (XXX) XXX-XXXX
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    
    // Return original if formatting is not possible
    return phone;
  }

  // Get hotel capacity display
  static String formatCapacity(int? totalRooms) {
    if (totalRooms == null || totalRooms == 0) {
      return 'Capacity not specified';
    }
    return '$totalRooms rooms';
  }

  // Calculate hotel occupancy rate (would need reservation data)
  static double calculateOccupancyRate(int totalRooms, int occupiedRooms) {
    if (totalRooms == 0) return 0.0;
    return (occupiedRooms / totalRooms) * 100;
  }

  // Format occupancy rate for display
  static String formatOccupancyRate(double rate) {
    return '${rate.toStringAsFixed(1)}%';
  }

  // Get recommended room rate based on various factors
  static double getRecommendedRate({
    required double baseRate,
    double? rating,
    List<String>? amenities,
    double occupancyRate = 0.0,
  }) {
    double rate = baseRate;

    // Adjust based on rating
    if (rating != null) {
      if (rating >= 4.5) {
        rate *= 1.2; // 20% premium for excellent hotels
      } else if (rating >= 4.0) {
        rate *= 1.1; // 10% premium for very good hotels
      } else if (rating < 3.0) {
        rate *= 0.9; // 10% discount for lower-rated hotels
      }
    }

    // Adjust based on amenities
    if (amenities != null) {
      if (amenities.contains('spa')) rate *= 1.05;
      if (amenities.contains('pool')) rate *= 1.03;
      if (amenities.contains('gym')) rate *= 1.02;
    }

    // Adjust based on occupancy (demand-based pricing)
    if (occupancyRate > 80) {
      rate *= 1.15; // High demand
    } else if (occupancyRate > 60) {
      rate *= 1.05; // Medium demand
    } else if (occupancyRate < 30) {
      rate *= 0.95; // Low demand discount
    }

    return rate;
  }

  // Check if hotel is featured (based on rating and amenities)
  static bool isFeaturedHotel(Hotel hotel) {
    if (hotel.rating != null && hotel.rating! >= 4.0) return true;
    if (hotel.amenities != null && hotel.amenities!.length >= 5) return true;
    return false;
  }

  // Get hotel category based on rating and amenities
  static String getHotelCategory(Hotel hotel) {
    if (hotel.rating != null && hotel.rating! >= 4.5) {
      return 'Luxury';
    } else if (hotel.rating != null && hotel.rating! >= 4.0) {
      return 'Premium';
    } else if (hotel.rating != null && hotel.rating! >= 3.5) {
      return 'Standard';
    } else if (hotel.rating != null && hotel.rating! >= 3.0) {
      return 'Budget';
    }
    return 'Basic';
  }

  // Sort hotels by various criteria
  static List<Hotel> sortHotels(List<Hotel> hotels, String sortBy) {
    List<Hotel> sortedHotels = List.from(hotels);
    
    switch (sortBy.toLowerCase()) {
      case 'name':
        sortedHotels.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'rating':
        sortedHotels.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'created':
        sortedHotels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'updated':
        sortedHotels.sort((a, b) => (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
        break;
      default:
        // Default sort by name
        sortedHotels.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return sortedHotels;
  }
}
