from django.shortcuts import render, redirect
from django.core.files import File
from pathlib import Path
from django.http import HttpResponse

def index(request):
	print('hey')
	return render(request, 'index.html')

def indexfile(request, index_file='/'):
	return redirect('/static/'+index_file)