package utils

import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.parisoft.noop.ui.editor.NoopEditor

import static extension org.eclipse.ui.handlers.HandlerUtil.*

class IResources {

	static def getIResource(ExecutionEvent event) {
		val editor = event.activeEditor

		if (editor instanceof NoopEditor) {
			editor.file
		} else {
			event.currentSelection.IResource
		}
	}

	static def getIResource(ISelection selection) {
		if (selection instanceof IStructuredSelection) {
			if (selection.size == 1) {
				val container = selection.firstElement

				val path = if (container instanceof IContainer) {
						container.fullPath
					} else if (container instanceof IResource) {
						container.parent.fullPath
					} else if (container.class.methods.exists[name == 'getPath' && returnType == IPath]) {
						val getPath = container.class.methods.findFirst[name == 'getPath' && returnType == IPath]
						getPath.accessible = true
						getPath.invoke(container) as IPath
					}

				if (path !== null) {
					if (path.segmentCount > 1) {
						return ResourcesPlugin::workspace.root.getFileForLocation(path) ?:
							ResourcesPlugin::workspace.root.getFolder(path)
					} else {
						ResourcesPlugin::workspace.root.projects.findFirst [
							location.lastSegment == path.lastSegment
						]
					}
				}
			}
		}
	}
}
