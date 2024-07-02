from .views import UserViewSet, healthcheck
from rest_framework import routers
from django.urls import path


router = routers.DefaultRouter()
router.register('users', UserViewSet, 'users')

urlpatterns = router.urls

urlpatterns += [
    path('health/', healthcheck, name='healthcheck'),
]
