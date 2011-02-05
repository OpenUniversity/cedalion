/*
 * Created on Jan 26, 2006
 */
package net.nansore.cedalion.figures;

import java.io.IOException;

import net.nansore.cedalion.eclipse.TermContext;
import net.nansore.cedalion.eclipse.TermVisualizationException;
import net.nansore.cedalion.helpers.FigureNavigator;
import net.nansore.prolog.Compound;

import org.eclipse.draw2d.Figure;
import org.eclipse.draw2d.FlowLayout;
import org.eclipse.draw2d.MouseEvent;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbenchPart;

/**
 * @author boaz
 */
public abstract class TermContextProxy extends Figure implements TermContext, TermFigure {

    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#getCanvas()
     */
    public Control getCanvas() {
        return context.getCanvas();
    }
    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#handleClick(org.eclipse.draw2d.MouseEvent)
     */
    public void handleClick(MouseEvent me) {
        context.handleClick(me);
    }
    public String getResource() {
    	return context.getResource();
	}
	/* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#figureUpdated()
     */
    public void figureUpdated() {
        context.figureUpdated();
    }
    /* (non-Javadoc)
     * @see net.nansore.visualterm.figures.TermFigure#updateFigure()
     */
    public void updateFigure() throws TermVisualizationException {
        // TODO Auto-generated method stub

    }
    private TermContext context;

    public TermContextProxy(TermContext parent) {
        context = parent;
        setLayoutManager(new FlowLayout());
        context.bindFigure(this);
    }
    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#getTextEditor()
     */
    public Text getTextEditor() {
        return context.getTextEditor();
    }

    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#bindFigure(net.nansore.visualterm.figures.TermFigure)
     */
    public void bindFigure(TermFigure figure) {
        context.bindFigure(figure);
    }

    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#selectionChanged(net.nansore.visualterm.figures.TermFigure)
     */
    public void selectionChanged(TermFigure figure) {
        context.selectionChanged(figure);
    }

    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#registerTermFigure(int, net.nansore.visualterm.figures.TermFigure)
     */
    public void registerTermFigure(Object termID, TermFigure figure) {
        context.registerTermFigure(termID, figure);
    }

    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#setFocus()
     */
    public void setFocus() {
        context.setFocus();
    }
    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#getColor()
     */
    public Color getColor() {
        return context.getColor();
    }
    @Override
	public Compound getPath() {
		return context.getPath();
	}
	/* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#getFont()
     */
    public Font getFont(int fontType) {
        return context.getFont(fontType);
    }
	public void unregisterTermFigure(Object id, TermFigure figure) {
	    context.unregisterTermFigure(id, figure);
	}
	public IWorkbenchPart getWorkbenchPart() {
		return context.getWorkbenchPart();
	}
    /* (non-Javadoc)
     * @see net.nansore.visualterm.TermContext#performDefaultAction()
     */
    public void performDefaultAction() {
        context.performDefaultAction();
    }
	public String getPackage() {
		return context.getPackage();
	}
	@Override
	public Image getImage(String imageName) throws IOException {
		return context.getImage(imageName);
	}
	@Override
	public VisualTerm getFocused() {
		return context.getFocused();
	}
	@Override
	public void setFocused(VisualTerm visualTerm) {
		context.setFocused(visualTerm);
	}
}
