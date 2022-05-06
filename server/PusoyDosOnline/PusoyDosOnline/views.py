from django.shortcuts import render, redirect
from django.core.files import File
from pathlib import Path
from django.http import HttpResponse

def index(request):
	print('hey')
	return render(request, 'index.html')

BASE_DIR = str(Path(__file__).resolve().parent.parent)
def indexjs(request):
	path_ = BASE_DIR+'/templates/index.js'
	with open(path_) as f:
		myfile = File(f)
		print('working', path_)
		response = HttpResponse(myfile)
		response['Content-type'] ='text/javascript'
	print('uhuh')
	return response
def indexpng(request):
	path_ = BASE_DIR+'/templates/index.apple-touch-icon.png'
	with open(path_) as f:
		myfile = File(f)
		print('working', path_)
		response = HttpResponse(myfile)
		response['Content-type'] ='image/png'
	print('uhuh')
	return response
# def indexpck(request):
# 	path_ = BASE_DIR+'/static/index.pck'
# 	with open(path_, encoding="ISO-8859-2") as f:
# 		myfile = File(f)
# 		print('working', path_)
# 		response = HttpResponse(myfile)
# 		#response['Content-type'] ='application/octet-stream'
# 	print('uhuh')
# 	return response
def indexpck(request):
	return redirect('/static/index.pck')
# def indexwasm(request):
# 	path_ = BASE_DIR+'/static/index.wasm'
# 	with open(path_, encoding="windows-1252") as f:
# 		myfile = File(f)
# 		print('working', path_)
# 		response = HttpResponse(myfile)
# 		response['Content-type'] ='application/wasm'
# 	print('uhuh')
# 	return response
def indexwasm(request):
	return redirect('/static/index.wasm')

def prac(request, practice="default"):
	print('heyy is me', practice)

def indexfile(request, index_file='/'):
	print("LOADING: "+'/static/'+index_file)
	return redirect('/static/'+index_file)