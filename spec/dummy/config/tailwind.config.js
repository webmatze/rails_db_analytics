const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    '/Users/mathiaskarstaedt/Workspace/cline/rails_db_analytics/app/views/**/*.erb',
    '/Users/mathiaskarstaedt/Workspace/cline/rails_db_analytics/app/components/**/*.erb',
    '/Users/mathiaskarstaedt/Workspace/cline/rails_db_analytics/app/helpers/**/*.rb',
    '/Users/mathiaskarstaedt/Workspace/cline/rails_db_analytics/app/controllers/**/*.rb',
'/Users/mathiaskarstaedt/Workspace/cline/rails_db_analytics/app/javascript/**/*.js',
'/Users/mathiaskarstaedt/Workspace/cline/rails_db_analytics/app/assets/stylesheets/**/*.css' 
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
  // Ensure styles are scoped to the engine
  // prefix: 'rda-',
  // corePlugins: {
  //   preflight: false,
  // },
}
