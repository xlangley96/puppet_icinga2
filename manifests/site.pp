# Disable file backups globally
File { backup => false }

# Apply classes dynamically via Hiera
node default {
  lookup('classes', Array[String[1]], 'unique').contain
}
