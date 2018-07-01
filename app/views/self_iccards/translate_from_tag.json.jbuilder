json.status @status
json.user_id @card.user.id rescue ''
json.user_number @card.user.profile.user_number rescue ''
json.name @card.user_name
