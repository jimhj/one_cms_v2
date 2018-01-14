# = require swiper

$(document).ready ->
  if $('.swiper-container').length > 0
    swiper = new Swiper '.swiper-container',
      pagination: '.swiper-pagination',
      paginationClickable: true,
      preloadImages: false,
      lazyLoading: true,
      autoplay: 2500,
      autoplayDisableOnInteraction: false